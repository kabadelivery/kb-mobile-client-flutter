import 'package:flutter/material.dart';

class DialogWithPages extends StatelessWidget {
  const DialogWithPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dialog PageView Example")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      PageController controller = PageController();

                      return SizedBox(
                        height: 300,
                        width: 300,
                        child: Column(
                          children: [
                            Expanded(
                              child: PageView(
                                controller: controller,
                                children: const [
                                  Center(child: Text("Page 1")),
                                  Center(child: Text("Page 2")),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    controller.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: const Text("Prev"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    controller.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: const Text("Next"),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
          child: const Text("Open Dialog"),
        ),
      ),
    );
  }
}
