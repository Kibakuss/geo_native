package com.example.geo_native

interface LocationCallback {
    fun onLocationUpdated(latitude: Double, longitude: Double)
}