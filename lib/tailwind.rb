class TailwindFilter < Nanoc::Filter
  identifier :tailwind
  type :binary

  def run(filename, params = {})
    system "./node_modules/.bin/sass #{filename} | ./node_modules/.bin/postcss > #{output_filename}"
  end
end
