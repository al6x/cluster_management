# we don't want to actually alter our computer, so here we definging stubs
class Vos::Box
  def fake_bash cmd
    cluster.logger.info "   => bash: '#{cmd}'"
    ""
  end
  
  # we need a place to store some metadata,
  # it needed for :apply_once and versioning
  def marks_dir
    dir "/tmp/marks"
  end
end