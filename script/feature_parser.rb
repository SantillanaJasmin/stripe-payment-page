require 'gherkin_ruby'

feature_file = File.read(ARGV[0]) if ARGV[0].present?
return 'Feature file not found' if feature_file.blank?

feature = GherkinRuby::Parser.new.parse(feature_file)
scenario = ARGV[1]

scenario_specs = [].tap do |arr|
  if scenario.present?
    steps = feature.scenarios.detect { |scenario| scenario.name == scenario }
    arr << scenario.steps.map { |step| "#{step.keyword} #{step.name}" }
  else
    feature.scenarios.map do |scenario|
      arr << scenario.steps.map { |step| "#{step.keyword} #{step.name}" }.join("\n")
    end
  end
end

return scenario_specs.join("\n\n")
