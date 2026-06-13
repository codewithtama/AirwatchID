package com.airwatchid.airwatch_id

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class AirWatchWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int
    ) {
        val prefs = HomeWidgetPlugin.getData(context)

        val city = prefs.getString("city", "Lokasi Saya") ?: "Lokasi Saya"
        val aqi = prefs.getInt("aqi", 0)
        val level = prefs.getString("level", "Memuat...") ?: "Memuat..."
        val colorInt = prefs.getInt("color", Color.parseColor("#00E676"))

        val views = RemoteViews(context.packageName, R.layout.airwatch_widget)

        views.setTextViewText(R.id.widget_aqi, if (aqi == 0) "--" else aqi.toString())
        views.setTextViewText(R.id.widget_city, city)
        views.setTextViewText(R.id.widget_level, level)
        views.setTextColor(R.id.widget_aqi, colorInt)

        // Tap to open app
        val launchIntent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context, 0, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

        appWidgetManager.updateAppWidget(widgetId, views)
    }
}
