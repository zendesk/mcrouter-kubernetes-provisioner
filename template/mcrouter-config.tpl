{
  "pools": {
    "default": {
      "servers": [ {{if .servers}}
        {{ range $key, $value := .servers }}"{{$value}}:11211",{{end}}
    {{end}}]
    }
  },
  "route": "PoolRoute|default"
}
