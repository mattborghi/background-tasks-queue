function parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @ | tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
      -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
      -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" $1 |
      awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

function push_to_heroku() {
   local GIT_HEROKU_REMOTE=$1
   local SUBFOLDER=$2
   local REMOTE_BRANCH=$3
   git push $GIT_HEROKU_REMOTE $(git subtree split --prefix $SUBFOLDER main):$REMOTE_BRANCH
}

# Define function to deploy on heroku
function up_to_heroku() {
   local APP_TYPE=$1
   local STATUS=$2
   local GIT_HEROKU_REMOTE=$3
   heroku ps:scale $APP_TYPE=$STATUS --remote $GIT_HEROKU_REMOTE
}
