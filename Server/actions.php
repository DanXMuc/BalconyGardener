<?php

function execute_action($action, $data)
{
	switch($action)
	{
		case "getSensorData":
			echo getSensorData($data);
		break;
		case "sensors":
			echo getSensors();
		break;
		default:
		break;
	}
}

function getSensorData($params)
{	
	$data = null;
	if(isset($params["sensorName"]))
	{
		$data = getSingleSensorData($params["sensorName"]);
	}
	else
	{
		$data = getAllSensorData();
	}
	$json = "{";
	
	$currentSensor = "";
	$currentSensorJson = "";
	$currentSensorDataJson = "";
	while($row = mysql_fetch_array($data, MYSQL_ASSOC))
	{
		if($row["SENSOR_NAME"] != $currentSensor)
		{
			if($currentSensorJson != "")
			{
				$json .= "]";
			}
			$json .= $currentSensorJson;
			
			$currentSensor = $row["SENSOR_NAME"];
			$currentSensorJson = "\"" . $currentSensor . "\": [";
		}	
		else
		{	
			$data = "{\"time\": " . $row["TIMESTAMP"] . ", \"value\": " . $row["VALUE"] . "}";
			
			if($currentSensorDataJson != "")
			{
				$currentSensorDataJson .= ", ";
			}
			$currentSensorDataJson .= $data;
		}
	}	
	$json .= "}";
	return $json;
}

function getSingleSensorData($name)
{
	return mysql_query("SELECT Sensors.NAME as SENSOR_NAME, SensorValues.VALUE, SensorValues.TIMESTAMP FROM SensorValues LEFT JOIN Sensors ON (SensorValues.SENSOR_ID=Sensors.ID) WHERE Sensors.NAME = \"$name\" ORDER BY SensorValues.TIMESTAMP ASC");
}

function getAllSensorData()
{
	return mysql_query("SELECT Sensors.NAME as SENSOR_NAME, SensorValues.VALUE, SensorValues.TIMESTAMP FROM SensorValues LEFT JOIN Sensors ON (SensorValues.SENSOR_ID=Sensors.ID) ORDER BY Sensors.ID ASC, SensorValues.TIMESTAMP ASC");
}

function getSensors()
{
	$res = mysql_query("SELECT Sensors.* FROM Sensors");
	$json = "";
	$json .= "{";
	
	$json .= "\"sensors\": [";
	$sensors = "";
	while($row = mysql_fetch_array($res, MYSQL_ASSOC))
	{
		$sensor = "\"" . $row["NAME"] ."\"";
		if($sensors != "")
		{
			$sensors .= ", ";
		}
		$sensors .= $sensor;
	}
	$json .= $sensors;	
	$json .="]}";
	
	return $json;	
}

?>
