# For testing purposes only. Do not use in production

import uuid
import hashlib
import os
from datetime import datetime, timedelta

TOKEN_VALID_FOR = 31 # in days

class AuthToken:
	def __init__(self, user_id, token, expires):
		self.user_id = user_id
		self.token = token
		self.expires = expires

class Authenticaton:

	def __init__(self):
		self.hashes = {}
		self.salts = {}
		self.user_ids = {}
		self.tokens = {}
		self.names = {}

	def hash_password(self, password, salt):
		return hashlib.pbkdf2_hmac('sha256', password.encode(), salt.encode(), 100000)

	def new_token(self):
		return str(uuid.uuid4())

	def name_for_id(self, user_id):
		return self.names[user_id]

	def update_hash(self, password, user_id):
		salt = os.urandom(16)
		salt = str(uuid.uuid1())
		self.salts[user_id] = salt
		password_hash = self.hash_password(password = password, salt = salt)
		self.hashes[user_id] = password_hash

	def is_password_valid(self, user_id, password):
		salt = self.salts[user_id]
		password_hash = self.hash_password(password = password, salt = salt)
		return self.hashes[user_id] == password_hash

	def log_in(self, email, password):
		user_id = self.user_ids[email]
		if user_id is None:
			return None
		if self.is_password_valid(user_id = user_id, password = password) is True:
			token_string = self.new_token()
			dt = datetime.now()
			td = timedelta(days = TOKEN_VALID_FOR)
			expires = dt + td
			token = AuthToken(user_id = user_id, token = token_string, expires = expires)
			self.tokens[user_id] = token
			return token
		else:
			return None

	def user_name_for(self, user_id):
		return self.names[user_id]

	def log_out(self, user_id, token):
		if self.tokens[user_id].token == token:
			self.tokens[user_id] = None
			return True
		else:
			return False

	def create_user(self, email, name, password):
		if email in self.user_ids.keys():
			return None
		user_id =  uuid.uuid1()
		self.user_ids[email] = user_id
		self.names[user_id] = name
		self.update_hash(password = password, user_id = user_id)
		token = self.log_in(email = email, password = password)
		return token

	def validate(self, user_id, token):
		login_tokin = self.tokens[user_id]
		if login_tokin is not None:
			if datetime.now() < login_tokin.expires:
				if login_tokin.token.__str__() == token.__str__():
					return login_tokin
			else:
				self.tokens[user_id] = None
		return None
