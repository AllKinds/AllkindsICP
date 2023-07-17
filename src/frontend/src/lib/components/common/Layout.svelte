
<div class="mx-auto min-h-screen flex flex-col scroll-smooth w-2/3">
	<!-- header/nav -->

	<div class="mx-auto h-14 flex justify-between w-11/12 fixed z-50">
		<slot name="logo" />

		<slot name="nav" />
	</div>

	<!-- main content -->
	<div class="mx-auto pb-16 pt-8 w-full">
		<slot name="main" />
	</div>
</div>
