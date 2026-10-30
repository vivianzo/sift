/// A button's label and what it does, for components that show one (`StatusView`, `Banner`).
struct CallToAction {
  let title: String
  let perform: () -> Void
}
