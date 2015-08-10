# ActiveRecord-Lite

### SQLObject
* ::all: return an array of all the records in the DB
* ::find: look up a single record by primary key
* #insert: insert a new row into the table to represent the SQLObject.
* #update: update the row with the id of this SQLObject
* #save: convenience method that either calls insert/update depending on whether or not the SQLObject already exists in the table.

### Searchable
* ::where: searchable method that returns results where a given condition is met

### Associations
* belongs_to, has_many, has_one through
* Sets default values #foreign_key, #class_name, #primary_key

### Future Extensions
- [ ] Write where so that it is lazy and stackable. Implement a Relation class.
- [ ] Validation methods/validator class.
- [ ] has_many :through
- [ ] This should handle both belongs_to => has_many and has_many => belongs_to.
- [ ] Write an includes method that does pre-fetching.
- [ ] Joins
