class Dev < Thor
  desc "cook", "package cookbooks and upload to homepage-cookbooks"
  def cook
    filename = "cookbooks.tar.gz"

    puts "Packaging cookbooks..."
    puts %x(cd cookbooks; berks package #{filename})

    puts "Uploading cookbooks to S3..."
    puts %x(aws s3api put-object --acl authenticated-read --bucket homepage-cookbooks --key #{filename} --body #{File.join("cookbooks", filename)} --profile personal)

    puts "Done"
  end
end
