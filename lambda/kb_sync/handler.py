import json
import logging
import os
import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))

bedrock_agent = boto3.client("bedrock-agent", region_name="us-east-1")


def lambda_handler(event: dict, context) -> dict:
    """
    Triggered by S3 ObjectCreated events on the KB source bucket.
    Starts a Bedrock ingestion job to re-index the knowledge base.

    CONSOLE DEPENDENCY: KB_ID env var is empty until the KB is created
    in console and kb_id is set in tfvars. Exits cleanly in that state.
    """
    kb_id = os.environ.get("KB_ID", "")
    data_source_id = os.environ.get("KB_DATA_SOURCE_ID", "")

    # Guard — exit cleanly if KB not yet created
    if not kb_id:
        logger.warning(
            "KB_ID not set. KB not yet created in console. "
            "Skipping ingestion job. Set kb_id in tfvars and re-apply."
        )
        return _response(200, {"status": "skipped", "reason": "KB_ID not configured"})

    if not data_source_id:
        logger.warning(
            "KB_DATA_SOURCE_ID not set. Skipping ingestion job."
        )
        return _response(200, {"status": "skipped", "reason": "KB_DATA_SOURCE_ID not configured"})

    # Log what triggered the sync
    records = event.get("Records", [])
    uploaded_keys = [
        r.get("s3", {}).get("object", {}).get("key", "unknown")
        for r in records
    ]
    logger.info("KB sync triggered by S3 upload(s): %s", uploaded_keys)

    try:
        response = bedrock_agent.start_ingestion_job(
            knowledgeBaseId=kb_id,
            dataSourceId=data_source_id,
        )

        job = response.get("ingestionJob", {})
        job_id = job.get("ingestionJobId", "")
        status = job.get("status", "")

        logger.info(
            "Ingestion job started. job_id=%s status=%s kb_id=%s",
            job_id, status, kb_id
        )

        return _response(200, {
            "status": "started",
            "ingestion_job_id": job_id,
            "ingestion_status": status,
            "triggered_by": uploaded_keys,
        })

    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        error_msg = e.response["Error"]["Message"]
        logger.error(
            "Failed to start ingestion job. error_code=%s message=%s",
            error_code, error_msg
        )
        return _response(500, {"status": "error", "error_code": error_code})


def _response(status_code: int, body: dict) -> dict:
    return {
        "statusCode": status_code,
        "body": json.dumps(body),
    }
