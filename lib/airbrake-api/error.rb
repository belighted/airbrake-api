module AirbrakeAPI
  class Error < AirbrakeAPI::Base

    def self.find(*args)
      setup

      results = case args.first
        when Fixnum
          find_individual(args)
        when :all
          find_all(args)
        else
          raise AirbrakeError.new('Invalid argument')
      end
      if results.nil? || results.errors
        p 'No results found or parsing error'
        []
      elsif results.errors
        p 'Errors when retrieving errors'
        []
      else
        results.group || results.groups
      end
    end

    def self.update(error, options)
      setup

      response = put(error_path(error), :body => options)
      if response.code == 403
        raise AirbrakeError.new('SSL should be enabled - use Airbrake.secure = true in configuration')
      end
      results = Hashie::Mash.new(response)

      raise AirbrakeError.new(results.errors.error) if results.errors
      results.group
    end

    private

    def self.find_all(args)
      options = args.extract_options!

      fetch(collection_path, options)
    end

    def self.find_individual(args)
      id = args.shift
      options = args.extract_options!

      fetch(error_path(id), options)
    end

    def self.collection_path
      '/errors.xml'
    end

    def self.error_path(error_id)
      "/errors/#{error_id}.xml"
    end

  end
end