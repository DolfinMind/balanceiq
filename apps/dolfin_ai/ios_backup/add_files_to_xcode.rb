require 'xcodeproj'

project_path = 'Runner.xcodeproj'
puts "Opening project at #{project_path}"
project = Xcodeproj::Project.open(project_path)

target = project.targets.find { |t| t.name == 'Runner' }
if target.nil?
  puts "Error: Runner target not found"
  exit 1
end

# Find the Runner group
runner_group = project.main_group.children.find { |c| (c.respond_to?(:display_name) && c.display_name == 'Runner') || (c.respond_to?(:path) && c.path == 'Runner') || (c.respond_to?(:name) && c.name == 'Runner') }
if runner_group.nil?
  puts "Error: Runner group not found. Main group children: #{project.main_group.children.map { |c| c.respond_to?(:display_name) ? c.display_name : (c.respond_to?(:name) ? c.name : c.path) }}"
  exit 1
end

files_to_add = ['GoogleService-Info.plist', 'PrivacyInfo.xcprivacy']

files_to_add.each do |filename|
  file_path = File.join('Runner', filename)
  
  # 1. Check if file exists on disk
  unless File.exist?(filename) # Relative to script in ios/Runner checks? No, script is in ios/
     # Check relative to where we run. We will run in apps/dolfin_ai/ios
     check_path = File.join(Dir.pwd, 'Runner', filename)
     unless File.exist?(check_path)
       puts "Warning: File #{filename} not found at #{check_path}. Skipping."
       next
     end
  end

  # 2. Check if already properly referenced
  # We look for a file reference in the group with the name
  existing_ref = runner_group.files.find { |f| f.path == filename || f.path == file_path }
  
  if existing_ref
    puts "#{filename} reference already exists in project."
    
    # Ensure it is in the target build phases
    # Resources build phase for plist/privacy
    resources_phase = target.resources_build_phase
    build_file = resources_phase.files.find { |bf| bf.file_ref == existing_ref }
    if build_file
       puts "#{filename} already in Resources build phase."
    else
       resources_phase.add_file_reference(existing_ref)
       puts "Added #{filename} to Resources build phase."
    end
  else
    # Create new reference
    # Since the file is in 'Runner/' folder and we are adding to 'Runner' group which likely has path 'Runner'
    # we usually just add the filename.
    file_ref = runner_group.new_reference(filename)
    target.add_resources([file_ref])
    puts "Added #{filename} to project and target."
  end
end

project.save
puts "Project saved."
