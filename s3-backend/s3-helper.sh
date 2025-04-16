aws s3api create-bucket \
    --bucket vhc-terraform-state-autohub-clients-v1 \
    --region us-east-1

# Habilitar versionamento (ALTAMENTE RECOMENDADO para recuperação de state)
aws s3api put-bucket-versioning \
    --bucket vhc-terraform-state-autohub-clients-v1 \
    --versioning-configuration Status=Enabled

# Habilitar criptografia (Boa prática)
aws s3api put-bucket-encryption \
    --bucket vhc-terraform-state-autohub-clients-v1 \
    --server-side-encryption-configuration '{
        "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
    }'