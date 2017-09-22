module ESLintRails
  class Config
    attr_reader :config

    def self.read(force_default: false)
      self.new(force_default: force_default).send(:read)
    end

    private

    # list of supported files ordered by preference
    CONFIG_FILES = [
      'config/eslint.json',
      '.eslintrc.js',
      '.eslintrc.yaml',
      '.eslintrc.yml',
      '.eslintrc.json'
    ].freeze
    private_constant :CONFIG_FILES

    def initialize(force_default: nil)
      raise(ArgumentError, 'force_default is required') if force_default.nil?

      @force_default = force_default
      @custom_file   = find_custom_config
      @default_file  = ESLintRails::Engine.root.join(CONFIG_FILES[0])
    end

    def read
      content = config_file.read
      @config = parse_content(content, config_file.extname)
    end

    def config_file
      (!@custom_file.nil? && !@force_default) ?  @custom_file : @default_file
    end

    # locates a config file based on expected set of paths
    def find_custom_config
      file = CONFIG_PATH.detect { |f| Rails.root.join(f).exist? }
      Rails.root.join(file) if file
    end

    # parses content based on fiel extension
    def parse_content(content, extname)
      case extname
      when '.js'
        ExecJS.eval(content)
      when '.json'
        JSON.parse(content)
      when '.yaml', '.yml'
        YAML.safe_load(content)
      else
        raise(ArgumentError, "invalid config file format: #{extname}")
      end
    end
  end
end
