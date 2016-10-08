# rhtml_to_html_erb.rake
namespace 'rhtml_to_html_erb' do
  desc 'Renames all your rhtml views to html.erb'
  task 'rename' do
    Dir.glob('app/views/**/*.rhtml').each do |file|
      puts `mv #{file} #{file.gsub(/\.rhtml$/, '.html.erb')}`
    end
  end
end
