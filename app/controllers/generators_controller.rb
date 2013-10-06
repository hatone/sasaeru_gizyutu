class GeneratorsController < ApplicationController
    ABSOLUTE_PATH = '/Users/hatone/SandBox/sasaeru/pub_images/'
    RELATIVE_PATH = 'public/images/'

  def render_list
    latest_id = Image.last.id.to_i
    @list1 = Image.find(latest_id)
    @list2 = Image.find(latest_id-1)
    @list3 = Image.find(latest_id-2)
    @list4 = Image.find(latest_id-3)
    @list5 = Image.find(latest_id-4)
    @list6 = Image.find(latest_id-5)
  end

  def index
    render_list
    @image_form = ImageForm.new
  end

  def create
    seed = Random.new_seed.to_s + request.env["HTTP_USER_AGENT"]
    id = Digest::SHA1.hexdigest(seed)
    filename = id + '.png'
    @image_form = ImageForm.new(params[:image_form])
  
    w = 256
    h = 256

    surface = Cairo::ImageSurface.new(w, h)
    context = Cairo::Context.new(surface)

    context.set_source_rgb(0, 0, 0) # 黒
    context.rectangle(0, 0, w, h)
    context.fill

    context.set_source_rgb(255, 255, 255)
    context.font_size = 25

    layout = context.create_pango_layout
    layout.width = w * Pango::SCALE
    layout.alignment = Pango::ALIGN_CENTER
    layout.text = @image_form.title
    context.show_pango_layout(layout)

    surface.write_to_png(RELATIVE_PATH + filename)

    price = (rand(99) +1)*100

    image = Image.new(filename: filename, price: price)
    image.save

    redirect_to :action => "show", :id =>id
  end

  def show
    render_list
    @id = params[:id]
    @ua = request.env["HTTP_USER_AGENT"]
    @test1 = "test"

    filename = @id +'.png'
    @image_exist = File.exist?(ABSOLUTE_PATH + filename)

  end
end
