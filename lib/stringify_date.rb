module StringifyDate
  def stringify_date(name, options={})
    
    defaults = {
      :format => :stringify_date_format,
      :stringified_name => "#{name}_string",
      :required => false,
      :required_message => 'is required'
    }
    
    options = defaults.merge(options)
    options[:invalid_message] ||= "is not in the right format. Example #{Date.new(2001,9,11).to_s(options[:format])}"
    options[:invalid_variable_name] ||= "@#{options[:stringified_name]}_invalid"
    
    # define 'read' method
    define_method "#{options[:stringified_name]}" do
      if instance_variable_defined?(options[:invalid_variable_name])
        instance_variable_get(options[:invalid_variable_name])
      else
        read_attribute(name).to_s(options[:format]) unless read_attribute(name).nil?
      end
    end

    # define 'write' method
    define_method "#{options[:stringified_name]}=" do |date_str|
      begin
        date_val = date_str.blank? ? nil : Date.strptime(date_str, ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS[options[:format]])
        send("#{name}=", date_val)
        
        if options[:required] && date_val.nil?
          instance_variable_set(options[:invalid_variable_name], nil)
        else
          remove_instance_variable(options[:invalid_variable_name]) if instance_variable_defined?(options[:invalid_variable_name])          
        end
      rescue ArgumentError
        instance_variable_set(options[:invalid_variable_name], date_str)
      end
    end
    
    define_method "validate_#{options[:stringified_name]}" do
      if instance_variable_defined?(options[:invalid_variable_name])
        invalid_date_str = instance_variable_get(options[:invalid_variable_name])
      
        if invalid_date_str.nil?
          send('errors').add(options[:stringified_name], options[:required_message]) 
        else
          send('errors').add(options[:stringified_name], options[:invalid_message]) 
        end

        return false
      end
    end
    
    validate "validate_#{options[:stringified_name]}".to_sym
  end
end

class ActiveRecord::Base
  extend StringifyDate
end