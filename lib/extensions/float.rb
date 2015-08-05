class Float
  def round_down(n=0)
    int,dec=self.to_s.split('.')
    "#{int}.#{dec[0..n-1]}".to_f
  end
end
