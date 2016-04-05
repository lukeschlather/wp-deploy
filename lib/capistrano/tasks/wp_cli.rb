def wp_cli(cmd)
  execute(File.join(fetch(:root_path), "bin/wp"), cmd)
end
