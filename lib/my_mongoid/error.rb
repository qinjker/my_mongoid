class MyMongoid::DuplicateFieldError < RuntimeError
end

class MyMongoid::UnknownAttributeError < RuntimeError
end

class MyMongoid::UnconfiguredDatabaseError < RuntimeError
end

class MyMongoid::RecordNotFoundError <  RuntimeError
end