mkdir .auth

cat > ./terraform/terraform.tfvars << EOF
yc__cloud_id = "$(yc config get cloud-id)"
yc__folder_id = "$(yc config get folder-id)"
yc__zone_id = "$(yc config get zone)"
EOF

yc iam key create --service-account-name terraform-sa --output ./terraform/auth.terraform.json