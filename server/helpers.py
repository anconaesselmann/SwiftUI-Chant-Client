
import uuid
import hashlib
import os
from datetime import datetime, timedelta
from SQLLiteAuthStore import *
from AuthToken import *

def hash_password(password, salt):
	return hashlib.pbkdf2_hmac('sha256', password.encode(), salt, 100000)

salt = os.urandom(16)

hashed = hash_password(password = "Hannibal2", salt = salt)



user_id = uuid.UUID("16805d30-02c3-11ec-94f7-3e22fb1a362f")
date = datetime.now()
token = AuthToken(user_id = user_id, token = uuid.uuid1(), expires = date)


# uuid = uuid.uuid1()

email = "axel.esselmann@gmail.com"

print(uuid)

store = SQLLiteAuthStore(database_name = 'temp.db')
store.delete_user(email = email)

if store.store_user(user_id = user_id, email = email, user_name = "DudeOnRock"):
	print("Inserted user ")
	store.store_hash(user_id = user_id, hash = hashed)
	store.store_salt(user_id = user_id, salt = salt)
	store.store_token(token = token)
else:
	print("User exists")

print("hash: ", store.get_hash(user_id = user_id))
print("hash: ", hashed)
print("salt: ", store.get_salt(user_id = user_id))
print("salt: ", salt)
t = store.get_token(user_id = user_id)
print("token: ", t.user_id, t.token, t.expires)
print("user_id: ", store.get_user_id(email = email))
print("user_name: ", store.get_user_name(user_id = user_id))

store.delete_token(user_id = user_id)
t = store.get_token(user_id = user_id)
print("Deleted token: ", t)





