extends Area2D



func _on_Fire_body_entered(body: Node) -> void:
	print(body.name)


func _on_startTimer_timeout() -> void:
	$anim.play("on")
