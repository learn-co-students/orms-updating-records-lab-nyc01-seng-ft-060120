require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id

  def initialize(id = nil, name, grade) 
      @id = id
      @name = name
      @grade = grade
  end

  def self.create_table 
    sql = <<-SQL 
        CREATE TABLE IF NOT EXISTS students ( 
            id INTEGER PRIMARY KEY,
            name TEXT, 
            grade TEXT 
            )
            SQL
    DB[:conn].execute(sql) 
end 

def self.drop_table
  sql = <<-SQL 
    DROP TABLE students
    SQL

    DB[:conn].execute(sql)
end

def save 
  if self.id
    self.update
  else
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?) 
    SQL

  DB[:conn].execute(sql, self.name, self.grade)

  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0] 
end 
end

def self.create (name, grade) 
  student = Student.new(name, grade) 
  student.save  
end 

def self.new_from_db(row)
  id = row[0] #using new because we aren't creating records
  name = row[1] #we're reading data from SQLite 
  grade = row[2] #and temporarily representing that data in Ruby 
  self.new(id, name, grade) 
end 

def self.find_by_name (name)
  sql = <<-SQL
    SELECT *
    FROM students
    WHERE name = ?
    LIMIT 1
   SQL
               
   DB[:conn].execute(sql, name).map do |row| 
    self.new_from_db(row)
end.first #return of map is an array, so we're grabbing the first element 
end 

def update 
  sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?" ###SQL update statement, using id get the correct record that Ruby and table share
  DB[:conn].execute(sql, self.name, self.grade, self.id) #Connect to database
end


end
