db.createUser({
  user: "root",
  pwd: "example",
  roles: [{ role: "readWrite", db: "meanDB" }]
});

db = db.getSiblingDB('meanDB');
db.createCollection('users');