package com.kaan.fitwalk

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class FitWalkWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.fitwalk_widget)

            val steps = widgetData.getInt("steps", 0)
            val goal = widgetData.getInt("goal", 6000)

            views.setTextViewText(R.id.widget_steps, steps.toString())
            views.setTextViewText(R.id.widget_goal, "/ $goal adım")
            views.setProgressBar(R.id.widget_progress, goal, steps.coerceAtMost(goal), false)

            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
