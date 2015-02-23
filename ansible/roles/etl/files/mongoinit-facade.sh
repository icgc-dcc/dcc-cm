#!/bin/bash -e
# Facade script around the mongoinit
# usage: See call in parent script
# point person: Anthony
# Openstack Version: no user/pass, no admins

# ===========================================================================
# Include dependency
source helpers/utils.sh
source helpers/cmd_builder.sh

# ---------------------------------------------------------------------------
# Sanity checks
ensure_user "dcc_dev"
ensure_pwd "overarch"

# ===========================================================================

jar_file=${1?} && shift
config_file=${1?} && shift
mongo_server=${1?} && shift
job_id=${1?} && shift

echo "jar_file=\"${jar_file?}\""
echo "config_file=\"${config_file?}\""
echo "mongo_server=\"${mongo_server?}\""
echo "job_id=\"${job_id?}\""

# ===========================================================================

admin_database_name="admin" # constant in mongodb

admin_database_user=admin
normal_database_user=admin
admin_database_user_passwd=dcc
normal_database_user_passwd=dcc

# ===========================================================================

echo
print_stdout_section_separator
new_cmd_builder
add_to_cmd "helpers/mongo.sh"
add_to_cmd "  ${mongo_server?}"
add_to_cmd "  ${admin_database_name?}"
add_to_cmd "  ${admin_database_user?}"
add_to_cmd "  ${admin_database_user_passwd?}"
add_to_cmd "  ${job_id?}" # = database name
add_to_cmd "  ${normal_database_user?}"
add_to_cmd "  ${normal_database_user_passwd?}"
cmd=$(build_cmd)
pretty_print_cmd "${cmd?}"
eval_cmd "${cmd?}"

# ===========================================================================

