class CodeSwapFilter < Nanoc3::Filter
  identifier :code_swap
  def run(content, params = {})
    content.gsub(/<pre class="(.+)"><code>/, '<pre><code class="language-\1">')
  end
end