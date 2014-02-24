class MyMongoid::DuplicateFieldError < RuntimeError
end

class MyMongoid::UnknownAttributeError < RuntimeError
end

class MyMongoid::UnconfiguredDatabaseError < RuntimeError
end