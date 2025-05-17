env: map (attrName: { name = attrName; value = env.${attrName}; }) (builtins.attrNames env)
