require 'pony'
require 'erb'

module EmailSender

  def send_hacker_summary(options={})
    options[:to] ||= 'jogara@localhost'
    options[:from] ||= 'johnogara@gmail.com'

    j = Pony.build_mail(:to => options[:to],
                        :from => options[:from],
                        :via => :smtp,
                        :subject  => 'HackerNews.com Front Page Summary',
                        :html_body => build_mail_content(:html),
                        :body => build_mail_content(:text))
    j.deliver
  end

  def build_mail_content(template_type = :html)
    @instance ||= self
    file_name = File.join(File.dirname(__FILE__), 'email_views', "summary.#{template_type.to_s}.erb")
    template = ERB.new(File.read(file_name))
    template.result(binding)
  end

end