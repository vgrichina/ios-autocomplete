import os
import sqlite3

db_path = "Autocomplete/names.sqlite"
os.remove(db_path)

db = sqlite3.connect(db_path)

db.execute("pragma synchronous=off")
db.execute("pragma journal_mode=memory")
db.execute("pragma temp_store=memory")

db.execute("create table names (name text)")
db.execute("create table parts (part text collate nocase)")
db.execute("""create table names_parts (part_id integer, name_id integer,
        foreign key(name_id) references names(rowid),
        foreign key(part_id) references parts(rowid))
""")
db.execute("create index parts_idx on parts (part)")
db.execute("create index names_parts_idx on names_parts (part_id, name_id)")

c = db.cursor()

all_parts = {}

for name in open("Autocomplete/fake-full-names.txt", "r"):
    name = name.replace("\n", "")

    c.execute("insert into names values (?)", (name,))
    name_id = c.lastrowid
    for part in name.split(" "):
        if len(part) > 1:
            if part in all_parts:
                part_id = all_parts[part]
            else:
                c.execute("insert into parts values(?)", (part,))
                part_id = c.lastrowid

            c.execute("insert into names_parts values (?, ?)", (part_id, name_id))

db.commit()
db.close()
