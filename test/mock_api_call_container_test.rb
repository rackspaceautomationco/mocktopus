require 'test_helper'

class MockApiCallContainerTest < Mocktopus::Test

  def test_initialize_not_nil
    container = Mocktopus::MockApiCallContainer.new
    refute_nil container
    assert_equal('Mocktopus::MockApiCallContainer', container.class.name)
  end

  def test_add
    container = Mocktopus::MockApiCallContainer.new
    call = Mocktopus::MockApiCall.new('/foo/bar', 'POST', {"header1" => "header_one"}, {"body1" => "body_one"})
    container.add(call)
  end

  def test_all
    container = Mocktopus::MockApiCallContainer.new
    10.times do |i|
      container.add(Mocktopus::MockApiCall.new("/foo/bar/#{i}", 'POST', {"header#{i}" => "header_#{i}"}, {"body#{i}" => "body_#{i}"}))
    end
    all = container.all
    refute_nil all.select{|a| a['path'] == '/foo/bar/0'}.first
  end

end
