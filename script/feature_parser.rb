require 'gherkin_ruby'

feature_file = File.read(ARGV[0]) if ARGV[0].present?
return 'Feature file not found' if feature_file.blank?

feature = GherkinRuby::Parser.new.parse(feature_file)
scenario = ARGV[1]

scenario_specs = [].tap do |arr|
  if scenario.present?
    steps = feature.scenarios.detect { |scen| scen.name == scenario }.try(:steps)
    arr << steps.map { |step| "#{step.keyword} #{step.name}" }
  else
    feature.scenarios.map do |scen|
      arr << scen.steps.map { |step| "#{step.keyword} #{step.name}" }.join("\n")
    end
  end
end

print scenario_specs.join("\n\n")
