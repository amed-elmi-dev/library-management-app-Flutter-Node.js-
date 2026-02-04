import "package:flutter/material.dart";
import "package:get/get.dart";
import "../../controllers/reservation_controller.dart";
import "../../theme/app_theme.dart";

class ReservationScreen extends StatelessWidget {
  const ReservationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReservationController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reservations"),
        actions: [
          IconButton(
            tooltip: "New reservation",
            icon: const Icon(Icons.add),
            onPressed: () {
              _showReservationModal(context);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.reservations.isEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value.isEmpty
                  ? "No data available"
                  : controller.errorMessage.value,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchReservations,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.reservations.length,
            itemBuilder: (context, index) {
              final reservation = controller.reservations[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(reservation.book?.title ?? "Unknown"),
                  subtitle: Text("Status: ${reservation.status}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.error),
                    tooltip: "Cancel reservation",
                    onPressed: () => controller.cancelReservation(reservation.id),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showReservationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "New Reservation",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  hintText: "Search book title",
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Select"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
