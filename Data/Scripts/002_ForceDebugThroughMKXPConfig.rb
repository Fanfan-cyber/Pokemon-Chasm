unless (defined? System::CONFIG).nil?
  $DEBUG = true if System::CONFIG["forceDebug"]
  $FORCECOMPILE = true if System::CONFIG["forceCompile"] && $DEBUG
end