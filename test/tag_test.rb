require "test/unit"
require "copperegg"

class TagTest < Test::Unit::TestCase

	def test_name_accessor_and_setter
		tag = CopperEgg::Tag.new(:name => "my_tag")

		assert_equal "my_tag", tag.name
	end

	def test_save_should_fail_if_name_is_blank
		tag = CopperEgg::Tag.new

		error = assert_raise(CopperEgg::ValidationError) { tag.save }
		assert_equal "Name can't be blank.", error.message
	end

	def test_save_should_fail_if_name_contains_invalid_characters
		tag = CopperEgg::Tag.new(:name => "my%%%tag")

		error = assert_raise(CopperEgg::ValidationError) { tag.save }
		assert_equal "Name contains invalid characters.", error.message
	end

	def test_objects_accessor_and_setter
		tag = CopperEgg::Tag.new(:name => "my_tag", :objects => [{"idv" => "obj1"}, {"idv" => "obj2"}])

		assert_equal ["obj1", "obj2"], tag.objects
	end

	def test_save_should_fail_if_no_objects_are_declared
		tag = CopperEgg::Tag.new(:name => "my_tag")

		error = assert_raise(CopperEgg::ValidationError) { tag.save }
		assert_equal "You must define at least one object.", error.message
	end

	def test_save_should_fail_if_objects_include_non_strings
		tag = CopperEgg::Tag.new(:name => "my_tag")
		tag.objects = ["obj1", 12323]

		error = assert_raise(CopperEgg::ValidationError) { tag.save }
		assert_equal "Invalid object identifier.", error.message
	end

	def test_to_hash
		tag = CopperEgg::Tag.new(:name => "test")
		tag.objects = ["obj1", "obj2"]

		assert tag.valid?
		hash = tag.to_hash

		assert_nil hash["id"]
		assert_equal "test", hash["tag"]
		assert_equal ["obj1", "obj2"], hash["ids"]
	end

end
