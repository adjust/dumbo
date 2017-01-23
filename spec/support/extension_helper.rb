module ExtensionHelper
  def install_testing_extension
    system <<-CMD
      (
        mkdir -p #{spec_root}/dumbo_sample_runtime && \
        cp -a #{spec_root}/dumbo_sample/* #{spec_root}/dumbo_sample_runtime
        cd #{spec_root}/dumbo_sample_runtime && \
        make -f #{spec_root}/dumbo_sample_runtime/Makefile && \
        make -f #{spec_root}/dumbo_sample_runtime/Makefile install
      ) 1> /dev/null
    CMD
  end

  def uninstall_testing_extension
    system <<-CMD
      (
        cd #{spec_root}/dumbo_sample_runtime && \
        make -f #{spec_root}/dumbo_sample_runtime/Makefile uninstall && \
        rm -rf #{spec_root}/dumbo_sample_runtime
      ) 1> /dev/null
    CMD
  end

  private

  def spec_root
    File.join(File.dirname(__FILE__), '..')
  end
end
