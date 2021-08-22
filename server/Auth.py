# For testing purposes only. Do not use in production

import uuid
from uuid import UUID
import hashlib
import os
from datetime import datetime, timedelta
from SQLLiteAuthStore import *
from AuthToken import *

TOKEN_VALID_FOR = 31 # in days

class Authenticaton:

	def __init__(self):
		# sqlite3 prod.db < tables.sql
		self.store = SQLLiteAuthStore(database_name = 'prod.db')

	def hash_password(self, password, salt):
		return hashlib.pbkdf2_hmac('sha256', password.encode(), salt, 100000)

	def new_token(self):
		return str(uuid.uuid4())

	def name_for_id(self, user_id):
		return self.store.get_user_name(user_id = user_id)

	def update_hash(self, password, user_id):
		salt = os.urandom(16)
		self.store.store_salt(user_id = user_id, salt = salt)
		password_hash = self.hash_password(password = password, salt = salt)
		self.store.store_hash(user_id = user_id, hash = password_hash)

	def is_password_valid(self, user_id, password):
		salt = self.store.get_salt(user_id = user_id)
		if not salt:
			print("no salt")
			return False
		password_hash = self.hash_password(password = password, salt = salt)
		stored_hash = self.store.get_hash(user_id = user_id)
		if stored_hash is not None:
			return password_hash == stored_hash
		else:
			return False

	def log_in(self, email, password):
		user_id = self.store.get_user_id(email = email)
		if user_id is None:
			return None
		if self.is_password_valid(user_id = user_id, password = password) is True:
			token_string = self.new_token()
			dt = datetime.now()
			td = timedelta(days = TOKEN_VALID_FOR)
			expires = dt + td
			token = AuthToken(user_id = user_id, token = token_string, expires = expires)
			self.store.store_token(token = token)
			return token
		else:
			return None

	def log_out(self, user_id: UUID, token_uuid: UUID):
		if self.validate(user_id = user_id, token_uuid = token_uuid):
			self.store.delete_token(user_id)
			return True
		return False

	def create_user(self, email: str, name: str, password: str):
		user_id =  uuid.uuid1()
		success = self.store.store_user(user_id = user_id, email = email, user_name = name)
		if not success:
			print("Existing user")
			return None
		self.update_hash(password = password, user_id = user_id)
		token = self.log_in(email = email, password = password)
		return token

	def validate(self, user_id: UUID, token_uuid: UUID):
		login_tokin = self.store.get_token(user_id = user_id)
		if login_tokin is not None:
			now = datetime.now()
			if now < login_tokin.expires:
				if login_tokin.token.__str__() == token_uuid.__str__():
					return login_tokin
			else:
				self.log_out(user_id = user_id, token_uuid = token_uuid)
		return None
