import sqlite3
db = sqlite3.connect("Autocomplete/names.sqlite")

c = db.cursor()

c.execute("create table names (name text)")
c.execute("create table names_index (name_part text collate nocase, name_id integer, foreign key(name_id) references names(rowid))")
c.execute("create index names_index_index on names_index(name_part)")

for name in open("Autocomplete/fake-full-names.txt", "r"):
    name = name.replace("\n", "")

    c.execute("insert into names values (?)", (name,))
    name_id = c.lastrowid
    for part in name.split(" "):
        if len(part) > 1:
            c.execute("insert into names_index values (?, ?)", (part, name_id))

db.commit()
db.close()
