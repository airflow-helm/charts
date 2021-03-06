from flask_appbuilder.security.manager import AUTH_DB

# use embedded DB for auth
AUTH_TYPE = AUTH_DB

# enable self-registration
AUTH_USER_REGISTRATION = True

# set self-registration role to admin
AUTH_USER_REGISTRATION_ROLE = "Admin"
