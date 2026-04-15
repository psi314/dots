function fish_prompt
    echo -s (set_color --bold yellow) (prompt_pwd --full-length-dirs 2) '> ' (set_color normal)
end
