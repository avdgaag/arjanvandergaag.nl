class CaptionsFilter < Nanoc3::Filter
  identifier :captions
  def run(content, params = {})
    content.gsub(%r{^<p>(<img[^>]*alt="([^"]+)"[^>]*>)</p>$}) do |m|
      image = $1
      alt_text = $2
      class_name = m[/ class="([^"]+)"/, 1]
      %Q{<div class="#{class_name}">\n\t#{image.sub(/ class="([^"]+)"/, '')}\n\t<p>#{alt_text}</p>\n</div>}
    end
  end
end