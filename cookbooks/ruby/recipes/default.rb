apt_repository 'ruby' do
  uri          'ppa:brightbox/ruby-ng'
  distribution node['lsb']['codename']
end

package "ruby#{node['ruby']['version']}"
package "ruby#{node['ruby']['version']}-dev"
package "rubygems"
gem_package "bundler"