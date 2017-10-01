describe package('git') do
  it { should be_installed }
end

describe package('nodejs') do
  it { should be_installed }
end

describe user('deploy') do
  it { should exist }
  its('uid') { should eq 31337 }
end

describe group('deploy') do
  it { should exist }
  its('gid') { should eq 1337 }
end