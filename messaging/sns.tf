# terraform/messaging/sns.tf

resource "aws_sns_topic" "main_bus" {
  name = "${var.main_sns_topic_name}-${var.environment}"

  tags = merge(
    var.project_tags,
    {
      Name        = "${var.main_sns_topic_name}-${var.environment}"
      Environment = var.environment
    }
  )
}