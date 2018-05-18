module CopperEgg
  class Tag
    include CopperEgg::Mixins::Persistence

    resource "tags"

    attr_accessor :name, :objects

    def load_attributes(attributes)
      @objects_original = []

      attributes.each do |name, value|
        if name.to_s == "id"
          @id = value
        elsif !respond_to?("#{name}=")
          next
        elsif name.to_s == "objects"
          @objects = value.map { |object| object["idv"].to_s.gsub(/\|$/, "") }
          @objects_original = @objects.clone
        else
          send "#{name}=", value
        end
      end
    end

    def name
      @name || @id
    end

    def valid?
      @error = nil

      if self.name.nil? || self.name.to_s.strip.empty?
        @error = "Name can't be blank."
        return false
      end

      if self.name.to_s.match(/[^\w-]/)
        @error = "Name contains invalid characters."
        return false
      end

      if self.objects.nil? || self.objects.empty?
        @error = "You must define at least one object."
        return false
      end

      unless self.objects.kind_of?(Array)
        @error = "Invalid objects field."
        return false
      end

      if self.objects.any? { |object| !object.kind_of?(String) }
        @error = "Invalid object identifier."
        return false
      end

      true
    end

    def delete
      self.class.request_200({:id => name, :request_type => "delete"})
    end

    def save
      unless valid?
        raise ValidationError.new(@error)
      end

      remove_objects(@objects_original - @objects)
      add_objects(@objects - @objects_original)
      @objects_original = @objects
    end

    def update
      save
    end

    def to_hash
      {"tag" => name, "ids" => objects}
    end

    private

    def remove_objects(ids)
      self.class.request_200({:id => name, :ids => ids, :request_type => "delete"}) unless ids.empty?
    end

    def add_objects(ids)
      self.class.request_200({:tag => name, :ids => ids, :request_type => "post"}) unless ids.empty?
    end

  end
end
