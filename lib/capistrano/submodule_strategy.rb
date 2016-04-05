module SubmoduleStrategy
  # do all the things a normal capistrano git session would do
  include Capistrano::Git::DefaultStrategy
  
  # check for a .git directory
  def test
    test! " [ -d #{repo_path}/.git ] "
  end
 
  # same as in Capistrano::Git::DefaultStrategy
  def check
    test! :git, :'ls-remote', repo_url
  end
 
  def clone
    git :clone, '-b', fetch(:branch), '--recursive', repo_url, repo_path
  end
 
  # same as in Capistrano::Git::DefaultStrategy
  def update
    git :remote, :update
  end
 
  # put the working tree in a release-branch,
  # make sure the submodules are up-to-date
  # and copy everything to the release path
  def release
    release_branch = fetch(:release_branch, File.basename(release_path))
    # -B is simpler but we're only on git 1.7 on my shared host :(
    branches = context.capture(:git, 'branch')
    flag = '-b'
    if branches.include?(release_branch)
      flag = ''
    end
    git :checkout, flag, release_branch
    git :branch, '--set-upstream', release_branch, fetch(:remote_branch, "origin/#{fetch(:branch)}")
    git :submodule, :update, '--init'
    git :pull
    context.execute "rsync -ar --filter=':- .wpignore' --exclude=.git\* #{repo_path}/ #{release_path}"
  end
end
