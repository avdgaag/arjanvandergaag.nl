class GzipFilter < Nanoc::Filter
  identifier :gzip
  type :binary

  def run(filename, params = {})
    system "gzip --best --to-stdout #{filename} > #{output_filename}"
  end
end

